#include <iostream>
#include <chrono>

#include <so_5/all.hpp>

using namespace std;
using namespace so_5;

using number = unsigned long long;

using disp_handle = disp::thread_pool::private_dispatcher_handle_t;

disp::thread_pool::bind_params_t bind_params()
{
	return disp::thread_pool::bind_params_t{}.fifo(
			disp::thread_pool::fifo_t::cooperation );
}

class skynet final : public agent_t
{
public :
	skynet(
		context_t ctx,
		disp_handle disp,
		mbox_t parent,
		number num,
		unsigned int size )
		:	agent_t{ ctx }
		,	m_disp{ move(disp) }
		,	m_parent{ move(parent) }
		,	m_num{ num }
		,	m_size{ size }
	{}

	virtual void so_evt_start() override
	{
		if( 1u == m_size )
			send< number >( m_parent, m_num );
		else
		{
			so_subscribe_self().event( [this]( number v ) {
					m_sum += v;
					if( ++m_received == divider )
						send< number >( m_parent, m_sum );
				} );

			create_agents();
		}
	}

private :
	static const unsigned int divider = 10;

	const disp_handle m_disp;
	const mbox_t m_parent;
	const number m_num;
	const unsigned int m_size;
	number m_sum = 0;
	unsigned int m_received = 0;

	void create_agents()
	{
		so_environment().introduce_coop(
			m_disp->binder( bind_params() ),
			[&]( coop_t & coop ) {
				const auto subsize = m_size / divider;
				for( unsigned int i = 0; i != divider; ++i )
					coop.make_agent< skynet >(
							m_disp, so_direct_mbox(), m_num + i * subsize, subsize );
			} );
	}
};

int main()
{
	so_5::launch( []( environment_t & env ) {
		auto tp_disp = disp::thread_pool::create_private_disp( env );

		auto result_ch = env.create_mchain( make_unlimited_mchain_params() );

		using clock_type = std::chrono::high_resolution_clock;
		const auto start_at = clock_type::now();

		env.introduce_coop( [&]( coop_t & coop ) {
			coop.make_agent< skynet >(
					tp_disp, result_ch->as_mbox(), 0u, 1000000u );
		} );

		number result = 0u;
		receive( result_ch, infinite_wait, [&result]( number v ) { result = v; } );

		const auto finish_at = clock_type::now();

		std::cout << "result: " << result
			<< ", time: " << chrono::duration_cast< chrono::milliseconds >(
					finish_at - start_at ).count() << "ms" << std::endl;

		env.stop();
	} );
}

